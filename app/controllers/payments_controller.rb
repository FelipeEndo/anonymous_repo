class PaymentsController < ApplicationController
  protect_from_forgery except: %i[complete_purchase request_purchase]
  skip_before_action :authenticate_admin!, only: %i[request_purchase complete_purchase]

  def request_purchase
    redirect_to my_orders_path, notice: 'Invalid action' unless order.present? && order.paid == false
    order.update_attributes(sale_channel: '123Pay')
    @payment = payment
    if @payment.save
      debugger
      create_order = create_payment_service.execute
    else
      redirect_to my_orders_path, notice: 'Your payment process is failed.'
    end
    if create_order[0].to_i == 1
      redirect_to create_order[2]
    else
      redirect_to my_orders_path, notice: 'Your payment process is failed.'
    end
  end

  def complete_purchase
    @transaction = find_transaction(params[:transactionID])
    if @transaction.present?
      update_transaction(complete_params)
      query_transaction
      if complete_params[:status].to_i == 1
        redirect_to my_orders_path, notice: 'Congrats ! Your payment is processed successfully.'
      else
        @transaction.order.update_attributes(status: :canceled, expired_at: Time.zone.now)
        redirect_to my_orders_path, notice: 'Your payment process is failed.'
      end
    else
      redirect_to my_orders_path, notice: 'Your payment process is failed.'
    end
  end

  private

  def update_order
    order = @transaction.order
    expired_date = order.order_details.upcoming_match.last.match.start_time
    order.update_attributes(paid: true, status: 'completed', expired_at: expired_date + 2.hours)
  end

  def update_transaction(info)
    @transaction.response = info
    @transaction.status = info[:status] || info[:transactionStatus]
    update_order if @transaction.status == 1
    @transaction.save!
  end

  def query_transaction
    query_order = query_payment_service.execute
    @transaction.response = {
      returnCode: query_order[0],
      '123PAYtransactionId': query_order[1],
      transactionStatus: query_order[2],
      totalAmount: query_order[3],
      bankCode: query_order[5],
    }
    @transaction.save!
  end

  def find_transaction(key)
    TransactionHistory.find_by(key: key)
  end

  def order
    current_customer.orders.find_by(id: params[:order_id])
  end

  def payment
    transaction = TransactionHistory.find_or_initialize_by(
      request_ip: params[:request_ip],
      order_id: params[:order_id],      
      customer_id: current_customer.id,
      amount: order.total_after_discount,
      status: 0
    )
    transaction.regenerate_key if transaction.present?
    transaction
  end

  def create_payment_service
    CreatePaymentService.new(@payment, current_customer)
  end

  def query_payment_service
    QueryPaymentService.new(@transaction)
  end

  def complete_params
    params.permit(
      :transactionID,
      :time,
      :status,
      :ticket
    )
  end
end
