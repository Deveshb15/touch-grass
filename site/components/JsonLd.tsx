// Renders structured data as a sanitized application/ld+json script
// (Next.js' recommended approach). Pass one object or an array of them.
export default function JsonLd({ data }: { data: object | object[] }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data).replace(/</g, "\\u003c") }}
    />
  );
}
