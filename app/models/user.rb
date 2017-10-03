class User < ActiveRecord::Base
	has_secure_password
	has_many :tweets
	has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following

	def slug
		input = self.username.downcase.split.collect{|string|string.scan(/[a-z0-9]/)}
		input.collect {|arr|arr.join("")}.join('-')
	end

	def self.find_by_slug(slug)
		collection = self.all
		collection.find {|instance| instance.slug == slug}
	end

	def follow(user_id)
    following_relationships.create(following_id: user_id)
  end

  def unfollow(user_id)
    following_relationships.find_by(following_id: user_id).destroy
  end

end