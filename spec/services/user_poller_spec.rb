require 'rails_helper'

describe UserPoller do
  context 'when the remote host is not reachable' do
    let(:logger) { double }
    let!(:user)   { create(:user, domain: 'notreachable.com', hosted: false) }

    before do
      allow_any_instance_of(User).to receive(:followings)
        .and_return(double(:empty? => false))

      allow(subject).to receive(:logger)
        .and_return(logger)

      expect(HTTParty).to receive(:get)
        .with('http://notreachable.com/posts.json', anything)
        .and_raise(SocketError)
    end

    it 'returns nil and logs an error' do
      expect(logger).to receive(:error)
      result = subject.perform('notreachable.com')
      expect(result).to eq(nil)
    end
  end
end
