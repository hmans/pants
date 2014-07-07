require 'rails_helper'

RSpec.describe PostSha, :type => :model do
  it 'validates presence of sha' do
    expect{ PostSha.create!(post_id: 1) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'validates the uniqness of sha' do
    PostSha.create!(post_id: 1, sha: 'test')
    expect{ PostSha.create!(post_id: 1, sha: 'test') }.to raise_error(ActiveRecord::RecordInvalid)
  end
end