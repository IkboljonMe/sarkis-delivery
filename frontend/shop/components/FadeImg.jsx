"use client";

// <img> that fades in once loaded; the parent supplies a placeholder background.
// Handles cache-hit images that complete before hydration attaches onLoad.

import { useEffect, useRef, useState } from "react";

export default function FadeImg({ className = "", alt = "", ...rest }) {
  const ref = useRef(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    if (ref.current?.complete) setLoaded(true);
  }, []);

  return (
    <img
      ref={ref}
      alt={alt}
      className={`img-fade${loaded ? " loaded" : ""}${className ? ` ${className}` : ""}`}
      onLoad={() => setLoaded(true)}
      {...rest}
    />
  );
}
