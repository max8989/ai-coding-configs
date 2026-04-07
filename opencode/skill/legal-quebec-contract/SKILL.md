---
name: legal-quebec-contract
description: Analyzes Quebec employment contracts for risks, fairness, and compliance with Civil Code of Québec and CNESST standards.
license: MIT
compatibility: opencode
---

# Quebec Employment Contract Analyzer

## When to use
Use this skill when the user shares a work contract from Quebec, Canada. Focus on:
- Termination clauses (reasonable notice, indemnity in lieu)
- Non-compete/non-solicit scope (time, geography, reasonableness under art. 2095 CCQ)
- IP ownership, confidentiality
- Compensation (base, bonus, vacation pay, overtime)
- Hours, remote work, probation
- Discrimination protections, leave rights

## Step-by-step analysis process
1. **Read the full contract** provided by user.
2. **Identify key Quebec rules**:
   - Civil Code of Québec (CCQ) articles 2085–2118 for employment.
   - CNESST guidelines: minimum wage, vacation 4%, notice periods.
   - Non-compete must be limited; broad ones often unenforceable.
3. **Flag risks**:
   - Use tables for issues: | Clause | Risk Level | Reason | Suggested fix |
   - High risk: Termination without cause with <2 weeks notice (senior roles expect more).
   - IP: Watch for overbroad assignment of future inventions.
4. **Output structure**:
   - Summary: Overall fairness (green/yellow/red).
   - Table of red flags.
   - Negotiation points.
   - Disclaimer: "Not legal advice; consult Quebec lawyer for binding opinion."
5. **If unclear**: Ask user for missing details (e.g., role seniority, salary).

## Tools to use
- Native OpenCode tools for reading/writing files if contract is attached.
- Web search sparingly for CNESST updates (e.g., "CNESST notice period Quebec 2026").

## Examples
**Input**: "Review this clause: 'Employee waives all notice upon termination.'"
**Output**:
| Clause | Risk | Reason | Fix |
|--------|------|--------|-----|
| Waiver | High | Violates CCQ art. 2091; can't waive indemnity. | Remove or limit to gross misconduct. |

Always end with: Recommend professional review for Quebec-specific advice.
