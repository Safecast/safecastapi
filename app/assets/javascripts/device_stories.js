window.addEventListener("load", () => {
  const url = new URL(document.location);

  document.querySelectorAll("[data-behavior='change-time-range']").forEach((el) => {
    const timeRange = el.dataset.timeRange;
    el.addEventListener("click", (e) => {
      e.preventDefault();
      window.location.href = url.pathname + "?time_range=" + timeRange;
    });
  })
});
