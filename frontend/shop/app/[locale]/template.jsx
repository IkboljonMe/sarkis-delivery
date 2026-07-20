// Remounts on every route change → retriggers the fade+rise entrance.
export default function Template({ children }) {
  return <div className="route-fade">{children}</div>;
}
