export async function sendNuiEvent(eventName: string, data: any = {}) {
  if (typeof GetParentResourceName === 'undefined') {
    return null;
  }
  try {
    const response = await fetch(`https://${GetParentResourceName()}/${eventName}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      return null;
    }
    try {
      return await response.json();
    } catch {
      return await response.text();
    }
  } catch {
    return null;
  }
}

declare function GetParentResourceName(): string;
