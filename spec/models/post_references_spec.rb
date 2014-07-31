require 'rails_helper'

RSpec.describe Post, :type => :model do
  let(:post) { build_stubbed(:post) }

  specify 'setting the referenced_url also sets the referenced_guid' do
    post.referenced_guid = nil
    post.referenced_url = 'http://test.com/abc123'
    expect(post.referenced_guid).to eq('test.com/abc123')
  end

  specify 'when referenced_guid is given but referenced_url is empty, it will use a fallback' do
    post.referenced_guid = 'test.com/abc123'
    post.send(:write_attribute, :referenced_url, nil)
    expect(post.referenced_guid).to eq('test.com/abc123')
    expect(post.referenced_url).to eq('http://test.com/abc123')
  end
end
