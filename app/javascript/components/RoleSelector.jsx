import React, { useState } from "react"

export default function RoleSelector({ roles, selectedRole, fieldName = "user[role]" }) {
  const [selected, setSelected] = useState(selectedRole || roles[0])

  return (
    <div className="role-selector">
      {roles.map((role) => (
        <label
          key={role}
          className={`role-option ${selected === role ? "role-option--selected" : ""}`}
        >
          <input
            type="radio"
            name={fieldName}
            value={role}
            checked={selected === role}
            onChange={() => setSelected(role)}
            className="role-option__input"
          />
          <span className="role-option__label">{role}</span>
        </label>
      ))}
    </div>
  )
}
