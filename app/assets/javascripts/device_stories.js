window.addEventListener("load", () => {
  const url = new URL(document.location);

  document.querySelectorAll("[data-behavior='change-time-range']").forEach((el) => {
    const timeRange = el.dataset.timeRange;
    el.addEventListener("click", (e) => {
      e.preventDefault();
      history.pushState({ time_range: timeRange }, el.innerText, `${url.pathname}?time_range=${timeRange}`);
    });
  })
});
