import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { PLAY_URL, APPSTORE_URL } from "../../config";

// QR-code target: printed/physical codes point here. Detects the device from
// the User-Agent and sends the visitor straight to the right store. Desktop /
// unknown UAs (e.g. someone opening the link on a laptop) fall back to the
// landing page instead of a dead end.
export default function QrCode() {
  const ua = headers().get("user-agent") || "";
  const isAndroid = /android/i.test(ua);
  const isIOS = /iphone|ipad|ipod/i.test(ua) || (/mac/i.test(ua) && /mobile/i.test(ua));

  if (isAndroid) redirect(PLAY_URL);
  if (isIOS) redirect(APPSTORE_URL);
  redirect("/");
}
