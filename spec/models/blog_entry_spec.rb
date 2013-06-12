require 'spec_helper'

describe BlogEntry do
  it { should validate_presence_of(:author) }
  it { should validate_presence_of(:title) }
  it { should belong_to(:user) }

  context "#content_html" do
    it "returns the post's content as html" do
      blog_entry = BlogEntry.new(content: "Some *markdown* content")

      html = blog_entry.content_html

      expect(html).to eq "<p>Some <em>markdown</em> content</p>\n"
    end
  end
end