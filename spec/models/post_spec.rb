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

  describe '#to_title' do
    subject { create(:post, body: body) }

    context "when the rendered body contains a heading" do
      let(:body) { "# A heading! It's awesome.\n\nSome more text.\n\n## Another heading!\n\nEven more text." }

      it "returns the text value of the heading" do
        expect(subject.to_title).to eq("A heading! It’s awesome.")
      end

      context "when the heading contains HTML tags" do
        let(:body) { "# A **heading**!\n\nSome more text.\n\n## Another heading!\n\nEven more text." }

        it "returns the text value without any of the HTML tags" do
          expect(subject.to_title).to eq("A heading!")
        end
      end
    end

    context "when the rendered body contains no heading element" do
      let(:body) { "Lorem to the Ipsum. Shmorem to the Shmipsum." }

      it "returns the first full sentence of the body" do
        expect(subject.to_title).to eq("Lorem to the Ipsum.")
      end
    end

    context "when the body contains quote blocks" do
      let(:body) { "> Unexpected.\n\nExpected." }

      it "ignores the blockquote before processing" do
        expect(subject.to_title).to eq("Expected.")
      end
    end
  end
end
