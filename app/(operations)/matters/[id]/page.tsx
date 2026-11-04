import { notFound } from "next/navigation";
import { getMatter, matters } from "../../_lib/data";
import { MatterOverviewClient } from "./matter-overview-client";

export function generateStaticParams() {
  return matters.map((matter) => ({ id: matter.id }));
}

export default async function MatterOverviewPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const matter = getMatter(id);

  if (!matter) notFound();

  return <MatterOverviewClient matter={matter} />;
}

