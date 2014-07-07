class TransferPostgresShas < ActiveRecord::Migration
  def up
    Post.all.each do |post|
      shas = post.read_attribute :previous_shas
      unless shas.empty?
        shas.each do |sha|
          post.shas.create! sha: sha
        end
      end

      post.shas.create! sha: post.pgsha
    end
  end
end
