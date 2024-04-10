window.addEventListener('DOMContentLoaded', function () {
  const openAll = document.querySelector('#open_all');
  if (openAll === null) {
    return;
  }
  openAll.addEventListener('click', function () {
    const importUrlList = JSON.parse(openAll.dataset.bgeigie || '{}');
    if (Array.isArray(importUrlList) && importUrlList.length > 0) {
      importUrlList.forEach(function (url) {
        window.open(url);
      });
    } else {
      alert("There are no unmoderated files on this side!");
    }
  });
});
