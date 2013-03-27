---
layout: default
title: Patric Fornasier's Blog
---
<h1>Posts</h1>

<div class="row-fluid">
  <div class="span12">
    <ul class="posts">
      {% for post in site.posts %}
        <li><span>{{ post.date | date_to_string }}</span><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
      {% endfor %}
    </ul>
  </div>
</div>
