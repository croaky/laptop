function find(selector) {
  return document.querySelectorAll(selector)[0]
}

function rewriteCommit() {
  console.log('rewritten');
  var prNumber = find(".gh-header-number").innerHTML.trim();
  var prTitle = find(".js-issue-title");
  var prBody = find("textarea[name='pull_request[body]']");
  var commitTitle = find(".merge-branch-form input[name='commit_title']");
  var commitMsg = find(".merge-branch-form textarea[name='commit_message']");

  commitTitle.value = prTitle.innerHTML.trim();
  commitMsg.innerHTML = prBody.value.trim() + "\n\n" + prNumber;
}

rewriteCommit();

var send = window.XMLHttpRequest.prototype.send;

function sendReplacement(data) {
  console.log(data)

  if (this.onreadystatechange) {
    this._onreadystatechange = this.onreadystatechange;
  }
  this.onreadystatechange = onReadyStateChangeReplacement;

  return send.apply(this, arguments);
}

function onReadyStateChangeReplacement() {
  rewriteCommit();

  if (this._onreadystatechange) {
    return this._onreadystatechange.apply(this, arguments);
  }
}

window.XMLHttpRequest.prototype.send = sendReplacement;
