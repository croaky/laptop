var t;

function sync() {
  var el = function (selector) {
    return document.querySelectorAll(selector)[0];
  };

  // copy PR title to commit title
  var commitTitle = el("input[name='commit_title']");
  var prTitle = el("input[name='issue[title]']");
  if (commitTitle && prTitle) {
    commitTitle.value = prTitle.value.trim();
  }

  // copy PR body and URL to commit message
  var commitMsg = el("textarea[name='commit_message']");
  var prBody = el("textarea[name='issue[body]']");
  if (commitMsg && prBody) {
    commitMsg.innerHTML = [prBody.value.trim(), window.location.href]
      .filter(function (el) {
        return el !== "";
      })
      .join("\n\n");
  }

  clearTimeout(t);
  t = setTimeout(function () {
    // sync when PR title is updated
    var prTitleForm = el("form.js-issue-update");
    prTitleForm && prTitleForm.addEventListener("submit", sync);

    // sync when PR body is updated
    var prBodyForm = el("form.js-comment-update");
    prBodyForm && prBodyForm.addEventListener("submit", sync);

    // sync when squash and merge button is clicked, confirm form opens
    var squashBtn = el("button.btn-group-squash");
    squashBtn && squashBtn.addEventListener("click", sync);
  }, 2000);
}

sync();
