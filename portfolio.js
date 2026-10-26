// Enhance navigation while keeping the complete page usable without JavaScript.
const links = [...document.querySelectorAll('.contents nav a')];
if ('IntersectionObserver' in window) {
  const observer = new IntersectionObserver(entries => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      const id = entry.target.id;
      for (const link of links) {
        const active = link.getAttribute('href') === '#' + id;
        link.classList.toggle('active', active);
        if (active) link.setAttribute('aria-current', 'location');
        else link.removeAttribute('aria-current');
      }
    }
  }, {rootMargin: '-5% 0px -70% 0px', threshold: 0});
  document.querySelectorAll('.section-body h2, #project-overview, #repository-files').forEach(section => observer.observe(section));
}
