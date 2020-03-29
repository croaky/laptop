function find(selector) {
  return document.querySelectorAll(selector)[0];
}

var prNum = find(".gh-header-number").innerHTML.trim();

function syncTitle() {
  var commitTitle = find("input[name='commit_title']");
  var prTitle = find("input[name='issue[title]']").value.trim();
  commitTitle.value = prTitle;

  // Form is replaced on each submit. Add new listener on each submit.
  setTimeout(function() {
    var prTitleForm = find(".js-issue-update");
    prTitleForm.addEventListener('submit', syncTitle);
  }, 2500);
};
syncTitle();

function syncBody() {
  var commitMsg = find("textarea[name='commit_message']");
  var prBody = find("textarea[name='pull_request[body]']").value.trim();
  commitMsg.innerHTML = prBody + "\n\n" + prNum;
};
syncBody();
var prBodyForm = find(".js-comment-update");
prBodyForm.addEventListener('submit', syncBody);
