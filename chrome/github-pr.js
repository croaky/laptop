function githubPR() {
  function find(selector) {
    return document.querySelectorAll(selector)[0];
  }

  var t;

  function sync() {
    var commitTitle = find("input[name='commit_title']");
    var prTitle = find("input[name='issue[title]']").value.trim();
    commitTitle.value = prTitle;

    var commitMsg = find("textarea[name='commit_message']");
    var prBody = find("textarea[name='pull_request[body]']").value.trim();
    var prNum = find(".gh-header-number").innerHTML.trim();
    commitMsg.innerHTML = prBody + "\n\n" + prNum;

    // Forms are replaced on each XHR submit. Reset listeners on each submit.
    clearTimeout(t);
    t = setTimeout(function() {
      var prTitleForm = find(".js-issue-update");
      prTitleForm.addEventListener('submit', sync);
      var prBodyForm = find(".js-comment-update");
      prBodyForm.addEventListener('submit', sync);
    }, 2500);
  };

  function isPR() {
    var url = window.location.href
    var parts = url.split('/').filter(function (el) { return el !== "" })
    return parts.length === 6 && parts[4] === "pull";
  }

  if (isPR()) {
    sync();
  };
};

if (document.readyState != 'loading') {
  githubPR();
} else {
  document.addEventListener('DOMContentLoaded', gitubPR);
}
