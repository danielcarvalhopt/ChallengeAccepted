require 'net/http'
require 'net/https'
require 'active_support/core_ext/hash'
require 'json'

class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # GET /challenges
  # GET /challenges.json
  def index
    @challenges = Challenge.all
  end

  # GET /challenges/1
  # GET /challenges/1.json
  def show
  end

  # GET /challenges/new
  def new
    @challenge = Challenge.new
  end

  # GET /challenges/1/edit
  def edit
  end

  def cancel
    @challenge = Challange.find_by_mw_id(params[:checkoutid])
    @challenge.state = State.find_by_description "Cancelled"
    @challenge.save
    redirect_to @challenge, :flash => { :error => "Payment Failed!" }
  end

  def confirm
    @challenge = Challange.find_by_mw_id(params[:checkoutid])
    @challenge.state = State.find_by_description "Proposed"
    @challenge.save
    redirect_to @challenge, notice: 'Payment received with success. Challange proposed!'
  end

  # POST /challenges
  # POST /challenges.json
  def create
    @challenge = Challenge.new(challenge_params)
    @challenge.state = State.find_by_description "Unconfirmed"
    @challenge.challenger = current_user

    if @challenge.save
      x = {
            payment:
            {
              client: 
              {
                name: current_user.name, 
                email: current_user.email, 
              },
              refundable: true,
              amount: @challenge.amount,
              currency: "EUR",
              items:[{
                ref: @challenge.id,
                name: "Challange Accepted - Apostas",
                descr:@challenge.description,
                amount: @challenge.amount,
                qt:1
                }]
              },
              url_confirm: "http://localhost:3000/challenges/confirm",
              url_cancel: "http://localhost:3000/challenges/cancel"
            }

      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => 'WalletPT 9d07218b9c7f24d7b166a3877b57103939876667'
      }

      uri = URI.parse('https://services.wallet.codebits.eu/api/v2/checkout')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      #data = {'payment' => x, 'amount' => 10}
      request = Net::HTTP::Post.new(uri.path, initheader = headers)
      request.body = x.to_json #data.to_json
      response = http.request(request)

      puts '----'
      puts response.body
      puts '----'

      d = JSON.parse(response.body)
      @challenge.mw_id = d['id']
      @challenge.save

      redirect_to d['url_redirect']

    else
      render action: 'new'
    end
  end

  # PATCH/PUT /challenges/1
  # PATCH/PUT /challenges/1.json
  def update
    respond_to do |format|
      if @challenge.update(challenge_params)
        format.html { redirect_to @challenge, notice: 'Challenge was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /challenges/1
  # DELETE /challenges/1.json
  def destroy
    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to challenges_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_challenge
      @challenge = Challenge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def challenge_params
      params.require(:challenge).permit(:challenged_id, :amount, :description)
    end
end
