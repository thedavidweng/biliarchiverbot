import { XMLParser } from "fast-xml-parser";

/**
 * Parse Internet Archive advancedsearch XML and return result/@numFound as a number.
 * Returns null when the attribute is missing or not a finite number.
 */
export function parseArchiveSearchNumFound(xml: string): number | null {
  const parser = new XMLParser({
    ignoreAttributes: false,
  });
  const obj = parser.parse(xml);
  const raw = obj?.response?.result?.["@_numFound"];
  if (raw === undefined || raw === null || raw === "") {
    return null;
  }
  const numFound = Number(raw);
  return Number.isFinite(numFound) ? numFound : null;
}
