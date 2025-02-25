import { NextRequest, NextResponse } from 'next/server';

/**
 * POST /api/consultation
 * Proxies the incoming request body to your AWS API Gateway endpoint
 * using an x-api-key stored in environment variables.
 */
export async function POST(request: NextRequest) {
  // Read environment variables (injected at build/runtime)
  const gatewayUrl = process.env.LANDHOLDERS_LAW_API_HOST;
  const apiKey = process.env.API_KEY;

  // Sanity checks
  if (!gatewayUrl || !apiKey) {
    console.error('Missing LANDHOLDERS_LAW_API_HOST or API_KEY');
    return NextResponse.json(
      { error: 'Server configuration error' },
      { status: 500 }
    );
  }

  try {
    // Parse the JSON body from the request
    const requestData = await request.json();

    // Forward the data to your API Gateway endpoint
    const gatewayResponse = await fetch(gatewayUrl+"/consultation", {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: JSON.stringify(requestData),
    });

    if (!gatewayResponse.ok) {
      // If API Gateway responded with an error status
      const errorText = await gatewayResponse.text();
      console.error('Gateway Error:', gatewayResponse.status, errorText);
      return NextResponse.json(
        { error: errorText || 'Error from API Gateway' },
        { status: gatewayResponse.status }
      );
    }

    // Attempt to parse the JSON body from the gateway response
    let responseBody;
    try {
      responseBody = await gatewayResponse.json();
    } catch {
      // In case the response isn't valid JSON
      responseBody = { success: true };
    }

    // Return success JSON to the client
    return NextResponse.json(responseBody, { status: 200 });

  } catch (error) {
    console.error('Proxy error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
