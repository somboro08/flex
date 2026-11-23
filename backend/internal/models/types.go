package models

import (
	"database/sql/driver"
	"fmt"
	"strings"
)

// StringArray permet de scanner des colonnes ARRAY PostgreSQL vers []string.
// GORM/pgx encodent nativement les slices pour l'INSERT ; côté lecture, le
// driver database/sql renvoie le littéral ("{a,b,c}") que l'on parse ici.
type StringArray []string

// Scan implémente sql.Scanner.
func (a *StringArray) Scan(src any) error {
	switch v := src.(type) {
	case nil:
		*a = nil
	case string:
		*a = parseArrayLiteral(v)
	case []byte:
		*a = parseArrayLiteral(string(v))
	case []string:
		*a = append((*a)[:0], v...)
	default:
		return fmt.Errorf("StringArray: unsupported scan source %T", src)
	}
	return nil
}

// Value implémente driver.Valuer. GORM ne sait pas formater les slices en
// littéral text[] pour PostgreSQL ; on renvoie la slice brute que pgx encode
// nativement en text[] via son NamedValueChecker.
func (a StringArray) Value() (driver.Value, error) {
	if a == nil {
		return nil, nil
	}
	return []string(a), nil
}

// parseArrayLiteral parse un littéral de tableau PostgreSQL "{a,b,\"c d\",NULL}".
func parseArrayLiteral(s string) []string {
	s = strings.TrimSpace(s)
	if len(s) < 2 || s[0] != '{' || s[len(s)-1] != '}' {
		return nil
	}
	body := s[1 : len(s)-1]
	if body == "" {
		return []string{}
	}
	var out []string
	var cur strings.Builder
	inQuotes := false
	for i := 0; i < len(body); i++ {
		c := body[i]
		switch {
		case c == '"':
			inQuotes = !inQuotes
		case c == '\\' && inQuotes && i+1 < len(body):
			i++
			cur.WriteByte(body[i])
		case c == ',' && !inQuotes:
			out = append(out, unquoteElement(cur.String()))
			cur.Reset()
		default:
			cur.WriteByte(c)
		}
	}
	out = append(out, unquoteElement(cur.String()))
	return out
}

func unquoteElement(s string) string {
	s = strings.TrimSpace(s)
	if s == "NULL" {
		return ""
	}
	return s
}
