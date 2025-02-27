// Generated by swift-openapi-generator, do not modify.
@_spi(Generated) import OpenAPIRuntime
#if os(Linux)
@preconcurrency import struct Foundation.URL
@preconcurrency import struct Foundation.Data
@preconcurrency import struct Foundation.Date
#else
import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.Date
#endif
import HTTPTypes
/// OFREP define the protocol for remote flag evaluations
package struct Client: APIProtocol {
    /// The underlying HTTP client.
    private let client: UniversalClient
    /// Creates a new client.
    /// - Parameters:
    ///   - serverURL: The server URL that the client connects to. Any server
    ///   URLs defined in the OpenAPI document are available as static methods
    ///   on the ``Servers`` type.
    ///   - configuration: A set of configuration values for the client.
    ///   - transport: A transport that performs HTTP operations.
    ///   - middlewares: A list of middlewares to call before the transport.
    package init(
        serverURL: Foundation.URL,
        configuration: Configuration = .init(),
        transport: any ClientTransport,
        middlewares: [any ClientMiddleware] = []
    ) {
        self.client = .init(
            serverURL: serverURL,
            configuration: configuration,
            transport: transport,
            middlewares: middlewares
        )
    }
    private var converter: Converter {
        client.converter
    }
    /// OFREP single flag evaluation contract
    ///
    /// OFREP single flag evaluation request.
    /// The endpoint is called by the server providers to perform single flag evaluation.
    ///
    ///
    /// - Remark: HTTP `POST /ofrep/v1/evaluate/flags/{key}`.
    /// - Remark: Generated from `#/paths//ofrep/v1/evaluate/flags/{key}/post(evaluateFlag)`.
    package func evaluateFlag(_ input: Operations.EvaluateFlag.Input) async throws -> Operations.EvaluateFlag.Output {
        try await client.send(
            input: input,
            forOperation: Operations.EvaluateFlag.id,
            serializer: { input in
                let path = try converter.renderedPath(
                    template: "/ofrep/v1/evaluate/flags/{}",
                    parameters: [
                        input.path.key
                    ]
                )
                var request: HTTPTypes.HTTPRequest = .init(
                    soar_path: path,
                    method: .post
                )
                suppressMutabilityWarning(&request)
                converter.setAcceptHeader(
                    in: &request.headerFields,
                    contentTypes: input.headers.accept
                )
                let body: OpenAPIRuntime.HTTPBody?
                switch input.body {
                case .none:
                    body = nil
                case let .json(value):
                    body = try converter.setOptionalRequestBodyAsJSON(
                        value,
                        headerFields: &request.headerFields,
                        contentType: "application/json; charset=utf-8"
                    )
                }
                return (request, body)
            },
            deserializer: { response, responseBody in
                switch response.status.code {
                case 200:
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.EvaluateFlag.Output.Ok.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.ServerEvaluationSuccess.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .ok(.init(body: body))
                case 400:
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.EvaluateFlag.Output.BadRequest.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.EvaluationFailure.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .badRequest(.init(body: body))
                case 404:
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.EvaluateFlag.Output.NotFound.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.FlagNotFound.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .notFound(.init(body: body))
                case 401:
                    return .unauthorized(.init())
                case 403:
                    return .forbidden(.init())
                case 429:
                    let headers: Operations.EvaluateFlag.Output.TooManyRequests.Headers = .init(retryAfter: try converter.getOptionalHeaderFieldAsURI(
                        in: response.headerFields,
                        name: "Retry-After",
                        as: Foundation.Date.self
                    ))
                    return .tooManyRequests(.init(headers: headers))
                case 500:
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.EvaluateFlag.Output.InternalServerError.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.GeneralErrorResponse.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .internalServerError(.init(body: body))
                default:
                    return .undocumented(
                        statusCode: response.status.code,
                        .init(
                            headerFields: response.headerFields,
                            body: responseBody
                        )
                    )
                }
            }
        )
    }
    /// OFREP bulk flag evaluation contract
    ///
    /// OFREP bulk evaluation request.
    /// The endpoint is called by the client providers to evaluate all flags at once.
    ///
    ///
    /// - Remark: HTTP `POST /ofrep/v1/evaluate/flags`.
    /// - Remark: Generated from `#/paths//ofrep/v1/evaluate/flags/post(evaluateFlagsBulk)`.
    package func evaluateFlagsBulk(_ input: Operations.EvaluateFlagsBulk.Input) async throws -> Operations.EvaluateFlagsBulk.Output {
        try await client.send(
            input: input,
            forOperation: Operations.EvaluateFlagsBulk.id,
            serializer: { input in
                let path = try converter.renderedPath(
                    template: "/ofrep/v1/evaluate/flags",
                    parameters: []
                )
                var request: HTTPTypes.HTTPRequest = .init(
                    soar_path: path,
                    method: .post
                )
                suppressMutabilityWarning(&request)
                try converter.setHeaderFieldAsURI(
                    in: &request.headerFields,
                    name: "If-None-Match",
                    value: input.headers.ifNoneMatch
                )
                converter.setAcceptHeader(
                    in: &request.headerFields,
                    contentTypes: input.headers.accept
                )
                let body: OpenAPIRuntime.HTTPBody?
                switch input.body {
                case .none:
                    body = nil
                case let .json(value):
                    body = try converter.setOptionalRequestBodyAsJSON(
                        value,
                        headerFields: &request.headerFields,
                        contentType: "application/json; charset=utf-8"
                    )
                }
                return (request, body)
            },
            deserializer: { response, responseBody in
                switch response.status.code {
                case 200:
                    let headers: Operations.EvaluateFlagsBulk.Output.Ok.Headers = .init(eTag: try converter.getOptionalHeaderFieldAsURI(
                        in: response.headerFields,
                        name: "ETag",
                        as: Swift.String.self
                    ))
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.EvaluateFlagsBulk.Output.Ok.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.BulkEvaluationSuccess.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .ok(.init(
                        headers: headers,
                        body: body
                    ))
                case 304:
                    return .notModified(.init())
                case 400:
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.EvaluateFlagsBulk.Output.BadRequest.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.BulkEvaluationFailure.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .badRequest(.init(body: body))
                case 401:
                    return .unauthorized(.init())
                case 403:
                    return .forbidden(.init())
                case 429:
                    let headers: Operations.EvaluateFlagsBulk.Output.TooManyRequests.Headers = .init(retryAfter: try converter.getOptionalHeaderFieldAsURI(
                        in: response.headerFields,
                        name: "Retry-After",
                        as: Foundation.Date.self
                    ))
                    return .tooManyRequests(.init(headers: headers))
                case 500:
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.EvaluateFlagsBulk.Output.InternalServerError.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.GeneralErrorResponse.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .internalServerError(.init(body: body))
                default:
                    return .undocumented(
                        statusCode: response.status.code,
                        .init(
                            headerFields: response.headerFields,
                            body: responseBody
                        )
                    )
                }
            }
        )
    }
    /// OFREP provider configuration
    ///
    /// OFREP configuration is used to supply information about the remote flag management system and to set up the OpenFeature SDK providers.
    /// The providers will contact this endpoint only if the client has opted in.
    ///
    ///
    /// - Remark: HTTP `GET /ofrep/v1/configuration`.
    /// - Remark: Generated from `#/paths//ofrep/v1/configuration/get(getConfiguration)`.
    package func getConfiguration(_ input: Operations.GetConfiguration.Input) async throws -> Operations.GetConfiguration.Output {
        try await client.send(
            input: input,
            forOperation: Operations.GetConfiguration.id,
            serializer: { input in
                let path = try converter.renderedPath(
                    template: "/ofrep/v1/configuration",
                    parameters: []
                )
                var request: HTTPTypes.HTTPRequest = .init(
                    soar_path: path,
                    method: .get
                )
                suppressMutabilityWarning(&request)
                try converter.setHeaderFieldAsURI(
                    in: &request.headerFields,
                    name: "If-None-Match",
                    value: input.headers.ifNoneMatch
                )
                converter.setAcceptHeader(
                    in: &request.headerFields,
                    contentTypes: input.headers.accept
                )
                return (request, nil)
            },
            deserializer: { response, responseBody in
                switch response.status.code {
                case 200:
                    let headers: Operations.GetConfiguration.Output.Ok.Headers = .init(eTag: try converter.getOptionalHeaderFieldAsURI(
                        in: response.headerFields,
                        name: "ETag",
                        as: Swift.String.self
                    ))
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.GetConfiguration.Output.Ok.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.ConfigurationResponse.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .ok(.init(
                        headers: headers,
                        body: body
                    ))
                case 304:
                    return .notModified(.init())
                case 401:
                    return .unauthorized(.init())
                case 403:
                    return .forbidden(.init())
                case 500:
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.GetConfiguration.Output.InternalServerError.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.GeneralErrorResponse.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .internalServerError(.init(body: body))
                default:
                    return .undocumented(
                        statusCode: response.status.code,
                        .init(
                            headerFields: response.headerFields,
                            body: responseBody
                        )
                    )
                }
            }
        )
    }
}
