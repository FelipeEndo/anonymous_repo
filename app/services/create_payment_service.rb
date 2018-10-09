class CreatePaymentService
  CREATE_ORDER = ENV['CREATE_ORDER']
  REDIRECT = 'http://' + ENV['APPLICATION_HOST'] + '/complete_purchase'.freeze

  # rubocop:disable all
  def initialize(payment, customer)
    @customer = customer
    @payment = payment
  end

  def execute
    JSON.parse(request.body)
  end

  private

  def request
    HTTParty.post(CREATE_ORDER, query: generate_query, headers: headers)
  end

  def headers
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  def generate_query
    {
      mTransactionID: @payment.key,
      merchantCode: ENV['123PAY_MERCHANT_CODE'],
      bankCode: '123PAY',
      totalAmount: round_amount(@payment.amount),
      clientIP: @payment.request_ip,
      custGender: 'U',
      cancelURL: REDIRECT,
      redirectURL: REDIRECT,
      errorURL: REDIRECT,
      passcode: ENV['123PAY_PASS_CODE'],
      checksum: checksum
    }
  end


  def round_amount(amount)
    format('%.0f', amount)
  end

  def checksum
    sum = @payment.key +
          ENV['123PAY_MERCHANT_CODE'] +
          '123PAY' +
          round_amount(@payment.amount) +
          @payment.request_ip +
          'U' +
          REDIRECT * 3 +
          ENV['123PAY_PASS_CODE'] +
          ENV['123PAY_SECRET_KEY']
    Digest::SHA1.hexdigest(sum)
  end
end
