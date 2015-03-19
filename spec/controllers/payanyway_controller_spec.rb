describe PayanywayController do
  routes { Payanyway::Engine.routes }

  describe 'GET #success' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:info).with("Called success payment url for order '676'")

      get :success, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #fail' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:error).with("Fail paid order '676'")

      get :fail, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #return' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:info).with("Return from payanyway. Order '676'")

      get :return, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #in_progress' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:info).with("Order '676' in progress")

      get :in_progress, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end
end