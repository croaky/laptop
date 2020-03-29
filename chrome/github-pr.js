function find(selector) {
  return document.querySelectorAll(selector)[0];
}

function sync() {
  var commitTitle = find("input[name='commit_title']");
  var prTitle = find("input[name='issue[title]']");
  if (commitTitle && prTitle) {
    commitTitle.value = prTitle.value.trim();
  }

  var commitMsg = find("textarea[name='commit_message']");
  var prBody = find("textarea[name='pull_request[body]']");
  var prNum = find(".gh-header-number");
  if (commitMsg && prBody && prNum) {
    commitMsg.innerHTML = prBody.value.trim() + "\n\n" + prNum.innerHTML.trim();
  }

  // Forms are replaced on each XHR submit. Add new listeners on each submit.
  setTimeout(function() {
    var prTitleForm = find(".js-issue-update");
    prTitleForm && prTitleForm.addEventListener('submit', sync);

    var prBodyForm = find(".js-comment-update");
    prBodyForm && prBodyForm.addEventListener('submit', sync);
  }, 2000);
};

sync();
