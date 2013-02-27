# irrelevant user
foo = 1
25.times do
  p = Post.create(:title => "Post #{foo.to_i}", :content => "#{Faker::Lorem.paragraph(5)}")
  5.times do
    c = p.comments.create(:content => "#{Faker::Lorem.paragraph(5)}")
  end
  foo = foo + 1
end