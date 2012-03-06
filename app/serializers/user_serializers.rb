module UserSerializers
  Summary = lambda { |u|
    {:url              => u.url,
     :avatar_micro_url => u.avatar.url(:micro),
     :nickname         => u.nickname}
  }
end
