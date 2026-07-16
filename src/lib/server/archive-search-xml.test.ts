import { describe, expect, it } from "vitest";
import { parseArchiveSearchNumFound } from "./archive-search-xml.js";

describe("parseArchiveSearchNumFound", () => {
  it("reads @_numFound from Internet Archive advancedsearch XML", () => {
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<response>
  <result numFound="3" start="0">
    <doc>
      <str name="identifier">BiliBili-BV1xx411c7mD_p1-demo</str>
    </doc>
  </result>
</response>`;

    expect(parseArchiveSearchNumFound(xml)).toBe(3);
  });

  it("returns null when numFound is missing", () => {
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<response>
  <result start="0"></result>
</response>`;

    expect(parseArchiveSearchNumFound(xml)).toBeNull();
  });

  it("treats numFound=0 as a present numeric zero", () => {
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<response>
  <result numFound="0" start="0"></result>
</response>`;

    expect(parseArchiveSearchNumFound(xml)).toBe(0);
  });
});
