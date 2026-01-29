import { ReactNode } from 'react';

export function Link({ to, children, className }: { to: string; children: ReactNode; className?: string }) {
  const handleClick = (e: React.MouseEvent) => {
    e.preventDefault();
    window.history.pushState({}, '', to);
    window.dispatchEvent(new PopStateEvent('popstate'));
  };

  return (
    <a href={to} onClick={handleClick} className={className}>
      {children}
    </a>
  );
}

export function useRouter() {
  const navigate = (path: string) => {
    window.history.pushState({}, '', path);
    window.dispatchEvent(new PopStateEvent('popstate'));
  };

  return { navigate };
}

export function getPath() {
  return window.location.pathname;
}

export function getSearchParams() {
  return new URLSearchParams(window.location.search);
}
