require 'net/http'
require 'net/https'
require 'active_support/core_ext/hash'
require 'json'

class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show, :edit, :update, :destroy, :complete, :fail, :pay, :accept]
  before_filter :authenticate_user!



  # GET /challenges
  # GET /challenges.json
  def my_challenges
    @challenges = current_user.challenged_challenges
  end

  def proposed_challenges
    @challenges = current_user.challenger_challenges
  end

  def other_challenges
    @challenges = Challenge.where.not(challenger_id: current_user.id, challenged_id: current_user.id)
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
    if params[:checkoutid].nil?
      @challenge = Challenge.find(params[:id])
    else
      @challenge = Challenge.find_by_mw_id(params[:checkoutid])
    end

    if @challenge.state.description.eql? "Proposed"
      refund
      @challenge.state = State.find_by_description "Cancelled"
      @challenge.save
      redirect_to @challenge, :flash => { :notice => "Challenge cancelled!" }
    elsif @challenge.state.description.eql? "Unconfirmed'"
      @challenge.state = State.find_by_description "Cancelled"
      @challenge.save
      redirect_to @challenge, :flash => { :error => "Payment Failed!" }
    else
      redirect_to @challenge, :flash => { :error => "Can't cancel challenge that is neither Unconfirmed or Proposed" }
    end
  end

  def confirm
    @challenge = Challenge.find_by_mw_id(params[:checkoutid])
    @challenge.state = State.find_by_description "Proposed"
    @challenge.save
    redirect_to @challenge, notice: 'Payment received with success. Challange proposed!'
  end

  def fail
    if @challenge.state.description.eql? "In Progress" 
      refund
      @challenge.state = State.find_by_description("Failed")
      @challenge.save
      redirect_to @challenge, notice: "Challenge failed! #{@challenge.amount} refunded to #{@challenge.challenger.email}"
    else
      redirect_to @challenge, notice: "Can't complete a challenge that is not in progress"
    end
  end

  def accept
    if @challenge.state.description.eql? "Proposed"
      @challenge.state = State.find_by_description("In Progress")
      @challenge.save
      redirect_to @challenge, notice: "Challenge accepted!"
    else
      redirect_to @challenge, notice: "Can't accept a challenge that is not proposed"
    end
  end

  def complete
    if @challenge.state.description.eql? "In Progress"
      x = {
              amount: @challenge.amount,
              method: "WALLET"
            }

      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => 'WalletPT 9d07218b9c7f24d7b166a3877b57103939876667'
      }

      uri = URI.parse("https://services.wallet.codebits.eu/api/v2/users/#{CGI.escape('@challenge.challenged.email')}/transfer")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.path, initheader = headers)
      request.body = x.to_json
      response = http.request(request)

      @challenge.state = State.find_by_description("Completed")
      @challenge.save
      redirect_to @challenge, notice: "Challenge completed! #{@challenge.amount} transferred to #{@challenge.challenged.email}"
    else
      redirect_to @challenge, notice: "Can't complete a challenge that is not in progress"
    end
  end

  # POST /challenges
  # POST /challenges.json
  def create
    @challenge = Challenge.new(challenge_params)
    @challenge.state = State.find_by_description "Unconfirmed"
    @challenge.challenger = current_user

    if @challenge.save
      pay_redirect
    else
      render action: 'new'
    end
  end

  def pay
    pay_redirect
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

    def refund
      x = {
            amount: @challenge.amount,
          }

          headers = {
            'Content-Type' => 'application/json',
            'Authorization' => 'WalletPT 9d07218b9c7f24d7b166a3877b57103939876667'
          }

          uri = URI.parse("https://services.wallet.codebits.eu/api/v2/operations/#{@challenge.mw_id}/refund")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          request = Net::HTTP::Post.new(uri.path, initheader = headers)
          request.body = x.to_json
          response = http.request(request)
    end

    def pay_redirect
      x = {
              payment:
              {
                client: 
                {
                  name: current_user.name, 
                  email: current_user.email, 
                },
                currency: "EUR",
                amount: @challenge.amount,
                type: "PAYMENT",
                items:[{
                  ref: @challenge.id,
                  name: "Create Challenge",
                  descr: @challenge.description,
                  amount: @challenge.amount,
                  qt:1
                  }],
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
        request = Net::HTTP::Post.new(uri.path, initheader = headers)
        request.body = x.to_json #data.to_json
        response = http.request(request)

        puts '----'
        puts response.body
        puts '----'

        d = JSON.parse(response.body)
        
        if d['code'].nil?  
          @challenge.mw_id = d['id']
          @challenge.save
          redirect_to d['url_redirect']
        else
          redirect_to @challenge, notice: "Error: #{d['message']}"
        end
      end

    # Never trust parameters from the scary internet, only allow the white list through.
    def challenge_params
      params.require(:challenge).permit(:challenged_id, :amount, :descriptio, :id)
    end
end
