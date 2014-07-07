class TransferPostgresTags < ActiveRecord::Migration
  def up
    Post.all.each do |post|
      tags = post.pgtags
      unless tags.empty?
        post.tag_list.add tags
        post.save!
      end
    end
  end
end
