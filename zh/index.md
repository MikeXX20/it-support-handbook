---
title: 首页
home: true
description: 面向日常工作与学习的 IT 支持、Linux 和 MySQL 实用手册，包含快速检查、故障排查和动手实验。
---

<div class="hero">
  <div class="eyebrow">日常工作的技术参考手册</div>
  <h1>排查有思路。<br><span>学习有实践。</span></h1>
  <p>随手查阅 Linux 与 MySQL 工作要点，通过小型实验理解命令背后的原理。</p>
  <div class="hero-actions">
    <a class="button primary" href="{{ '/zh/docs/quick-check.html' | relative_url }}">打开快速检查 <span aria-hidden="true">→</span></a>
    <a class="button secondary" href="{{ '/zh/learning/roadmap.html' | relative_url }}">开始学习</a>
  </div>
  <div class="hero-meta"><span>LINUX</span><span>MYSQL</span><span>IT 支持</span><span>动手实验</span></div>
</div>

<section class="start-panel" aria-labelledby="start-heading">
  <div><span class="eyebrow">遇到故障？</span><h2 id="start-heading">从症状开始。</h2><p>记录影响范围与发生时间，收集少量关键证据，再选择对应的排查路径。</p></div>
  <a href="{{ '/zh/docs/quick-check.html' | relative_url }}">五分钟快速定位 <span aria-hidden="true">↗</span></a>
</section>

<div class="section-heading"><h2>把常用知识放在手边。</h2><span>工作速查</span></div>
<div class="topic-grid">
  <a class="topic-card" href="{{ '/zh/docs/linux/commands.html' | relative_url }}"><span class="topic-icon" aria-hidden="true">$_</span><span class="card-label">01 / LINUX</span><h3>看懂主机状态。</h3><p>进程、内存、磁盘、权限、服务，以及串起问题线索的日志。</p><span class="card-action">Linux 命令速查 →</span></a>
  <a class="topic-card" href="{{ '/zh/docs/mysql/commands.html' | relative_url }}"><span class="topic-icon" aria-hidden="true">db</span><span class="card-label">02 / MYSQL</span><h3>理解数据库运行。</h3><p>连接、负载、事务、锁等待与执行计划，逐步缩小问题范围。</p><span class="card-action">MySQL 命令速查 →</span></a>
  <a class="topic-card" href="{{ '/zh/docs/linux/networking.html' | relative_url }}"><span class="topic-icon" aria-hidden="true">↔</span><span class="card-label">03 / 网络连接</span><h3>沿着请求找问题。</h3><p>逐层区分 DNS、路由、TCP、TLS 与应用故障。</p><span class="card-action">网络排查 →</span></a>
</div>

<div class="section-heading"><h2>把笔记变成技能。</h2><span>学习路线</span></div>
<div class="learning-grid">
  <a class="learning-card" href="{{ '/zh/learning/roadmap.html' | relative_url }}"><span class="number">04</span><div><span class="card-label">周 / 一条清晰路线</span><h3>打好工作基础。</h3><p>从 Linux 入门，到 MySQL 排查与恢复，循序渐进。</p></div><span aria-hidden="true">↗</span></a>
  <div class="lab-links"><a href="{{ '/zh/labs/linux-basics.html' | relative_url }}"><span>01</span><div><strong>Linux 实践实验</strong><small>文件、权限、进程与证据</small></div><span aria-hidden="true">→</span></a><a href="{{ '/zh/labs/mysql-basics.html' | relative_url }}"><span>02</span><div><strong>MySQL 实践实验</strong><small>查询、事务、锁与恢复</small></div><span aria-hidden="true">→</span></a></div>
</div>

<div class="working-note"><strong>好的检查，应该回答一个问题。</strong><p>每篇指南都将命令、结果解释与下一步关联起来，并标明观察操作与实验变更，方便在工作和学习中正确使用。</p><a href="{{ '/zh/docs/it-support/workflow.html' | relative_url }}">阅读 IT 支持工作流程 →</a></div>
