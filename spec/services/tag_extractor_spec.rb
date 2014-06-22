require 'rails_helper'

describe TagExtractor do
  describe '#extract_tags' do
    it 'correctly extracts hashtags from a string' do
      expect(TagExtractor.extract_tags('Hello #world, how are #things?')).to eq(['world', 'things'])
    end
  end
end
