module ResponseDecoders exposing (..)

import Json.Decode
import Json.Decode.Pipeline
import Json.Encode


type alias Response =
    { metadata : ResponseMetadata
    , results : List Project
    }


type alias ResponseMetadataResult_set =
    { count : Int
    , offset : Int
    , limit : Int
    , total : Int
    }


type alias ResponseMetadata =
    { result_set : ResponseMetadataResult_set
    }


decodeResponse : Json.Decode.Decoder Response
decodeResponse =
    Json.Decode.Pipeline.decode Response
        |> Json.Decode.Pipeline.required "metadata" decodeResponseMetadata
        |> Json.Decode.Pipeline.required "results" (Json.Decode.list decodeProject)


decodeResponseMetadataResult_set : Json.Decode.Decoder ResponseMetadataResult_set
decodeResponseMetadataResult_set =
    Json.Decode.Pipeline.decode ResponseMetadataResult_set
        |> Json.Decode.Pipeline.required "count" Json.Decode.int
        |> Json.Decode.Pipeline.required "offset" Json.Decode.int
        |> Json.Decode.Pipeline.required "limit" Json.Decode.int
        |> Json.Decode.Pipeline.required "total" Json.Decode.int


decodeResponseMetadata : Json.Decode.Decoder ResponseMetadata
decodeResponseMetadata =
    Json.Decode.Pipeline.decode ResponseMetadata
        |> Json.Decode.Pipeline.required "result_set" decodeResponseMetadataResult_set


type alias Project =
    { id : Int
    , proj_name : String
    }


decodeProject : Json.Decode.Decoder Project
decodeProject =
    Json.Decode.Pipeline.decode Project
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "proj_name" Json.Decode.string
