function find(selector) {
  return document.querySelectorAll(selector)[0];
}

var t;

function sync() {
  // copy PR title to commit title
  var commitTitle = find("input[name='commit_title']");
  var prTitle = find("input[name='issue[title]']");
  if (commitTitle && prTitle) {
    commitTitle.value = prTitle.value.trim();
  }

  // copy PR body and number to commit message
  var commitMsg = find("textarea[name='commit_message']");
  var prBody = find("textarea[name='pull_request[body]']");
  var prNum = find(".gh-header-number");
  if (commitMsg && prBody && prNum) {
    commitMsg.innerHTML = prBody.value.trim() + "\n\n" + prNum.innerHTML.trim();
  }

  clearTimeout(t);
  t = setTimeout(function() {
    // sync when PR title is updated
    var prTitleForm = find(".js-issue-update");
    prTitleForm && prTitleForm.addEventListener('submit', sync);

    // sync when PR body is updated
    var prBodyForm = find(".js-comment-update");
    prBodyForm && prBodyForm.addEventListener('submit', sync);

    // sync when squash and merge button is clicked, confirm form opens
    var squashBtn = find(".btn-group-squash");
    squashBtn && squashBtn.addEventListener('click', sync);
  }, 2000);
};

sync();
