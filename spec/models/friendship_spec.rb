require 'rails_helper'

describe Friendship do
  let(:user) { build_stubbed(:user) }

  it 'is not valid if users are equal' do
    subject.friend = subject.user = user
    expect(subject).to_not be_valid
  end
end
