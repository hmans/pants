require 'rails_helper'

RSpec.describe Post, :type => :model do
  describe '#sha' do
    it 'is automatically generated when validating a post instance' do
      post = build(:post)
      expect(post.sha).to be_blank
      post.valid?
      expect(post.sha).to_not be_blank
    end
  end
end
