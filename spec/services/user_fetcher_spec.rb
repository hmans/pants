require 'rails_helper'

describe UserFetcher do
  context 'when the remote host is not reachable' do
    let(:logger) { double }

    before do
      allow(subject).to receive(:logger)
        .and_return(logger)

      expect(HTTParty).to receive(:get)
        .with('http://notreachable.com')
        .and_raise(SocketError)
    end

    it 'returns nil and logs an error' do
      expect(logger).to receive(:error)
      result = subject.perform('http://notreachable.com')
      expect(result).to eq(nil)
    end
  end
end
