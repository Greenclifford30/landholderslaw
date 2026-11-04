import Image from "next/image";
import tedPortrait from "@/public/profile.png";

export default function AttorneyPortrait() {
  return (
    <div className="mx-auto w-full max-w-[28rem] bg-charcoal lg:mx-0">
      <Image
        src={tedPortrait}
        alt="Ted M. Word, Esq."
        className="h-auto w-full"
        priority
        sizes="(max-width: 1023px) min(100vw - 40px, 448px), 35vw"
      />
    </div>
  );
}
