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

  context 'when body contains hashtags' do
    subject do
      create(:post, body: 'Hello #world, I feel #fine!')
    end

    it 'extracts those hashtags into the #tags attribute' do
      expect(subject.tags).to eq(['world', 'fine'])
    end


    specify 'body_html contains auto-linked hashtags'
  end

  context 'when a line in the body starts with a hashtag' do
    subject do
      create(:post, body: "#hello\n\n#world, you're #awesome!")
    end

    it "doesn't convert the hashtag into a HTML heading" do
      expect(subject.tags).to eq(['hello', 'world', 'awesome'])
    end
  end
end
