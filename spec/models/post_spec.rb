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

  context 'when body changes' do
    subject { create(:post, body: 'One') }

    it 'changes its #sha' do
      expect { subject.update_attributes(body: 'Two') }
        .to change { subject.sha }
    end

    it 'stores the previous #sha in #previous_shas' do
      sha1 = subject.sha

      expect { subject.update_attributes(body: 'Two') }
        .to change { subject.previous_shas }
        .from([])
        .to([sha1])

      sha2 = subject.sha

      expect { subject.update_attributes(body: 'Three') }
        .to change { subject.previous_shas }
        .from([sha1])
        .to([sha1, sha2])
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

  describe '.fetch_from' do
    it 'performs a HTTP request to fetch the referenced URL'
    it 'always adds the json format parameter'
    it "checks the post's GUID against the given URL"
    it "checks the post's domain against the given URL"
    it "checks the post's slug against the given URL"
    it "doesn't check the post JSON's URL against the given URL"  # since the post may move from HTTP to HTTPS

    context "when the JSON's GUID is not in the database" do
      it "creates a new Post"
    end

    context "when the JSON's GUID is already in the database" do
      it "updates the existing Post"
    end

    it "only only allows certain fields to be copied"
  end
end
