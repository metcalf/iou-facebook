class FBUserStub

  FRIEND_MAP = {
                616421 => [1253603666, 1261073945],
                1253603666 => [616421],
                1261073945 => [616421],
                627182 => [616546,616716,616856,617378,618533,617504,619493,619642,615619,625023,615664,616338]
                }
  
  
  def initialize(id)
    @uid = id.to_i
    @friends = FRIEND_MAP[@uid]
  end
  
  def friends_with?(user_id)
    throw "Only works for id's" unless user_id.kind_of?(String) or user_id.kind_of?(Integer)
    return @friends.include?(user_id.to_i)
  end

end