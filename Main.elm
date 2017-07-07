module Main exposing (..)

import BasicAuth
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http as RHttp
import ResponseDecoders as Decoders exposing (Project, Response)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { username : String
    , password : String
    , baseUrl : String
    , project : String
    , projects : WebDataProjects
    , page : Page
    }


type alias WebDataProjects =
    WebData Response


type alias Projects =
    Response


type Page
    = LoginPage
    | PickingProjectPage


init : ( Model, Cmd Msg )
init =
    { username = ""
    , password = ""
    , baseUrl = ""
    , project = ""
    , projects = NotAsked
    , page = LoginPage
    }
        ! []



-- UPDATE


type Msg
    = OnLogin
    | OnLogout
    | OnUrlInput String
    | OnUserInput String
    | OnPasswordInput String
    | OnGetProjectsResult WebDataProjects


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        debugMsg =
            Debug.log "msg" msg

        debugModel =
            Debug.log "model" model
    in
    case msg of
        OnLogin ->
            onLogin model

        OnLogout ->
            { model | page = LoginPage, projects = NotAsked } ! []

        OnUrlInput url ->
            { model | baseUrl = url } ! []

        OnUserInput user ->
            { model | username = user } ! []

        OnPasswordInput pass ->
            { model | password = pass } ! []

        OnGetProjectsResult result ->
            { model | projects = result } ! []


onLogin : Model -> ( Model, Cmd Msg )
onLogin model =
    { model | page = PickingProjectPage, projects = Loading } ! [ getProjects model ]



-- VIEW


view : Model -> Html Msg
view model =
    case model.page of
        LoginPage ->
            loginView model

        PickingProjectPage ->
            pickProjectView model


loginView : Model -> Html Msg
loginView model =
    div []
        [ div []
            [ input
                [ type_ "text"
                , placeholder "QA Complete URL"
                , onInput OnUrlInput
                , value model.baseUrl
                ]
                []
            ]
        , div []
            [ input
                [ type_ "text"
                , placeholder "User"
                , onInput OnUserInput
                , value model.username
                ]
                []
            ]
        , div []
            [ input
                [ type_ "password"
                , placeholder "Password"
                , onInput OnPasswordInput
                , value model.password
                ]
                []
            ]
        , button [ onClick OnLogin ] [ text "Login" ]
        ]


pickProjectView : Model -> Html Msg
pickProjectView model =
    case model.projects of
        NotAsked ->
            text "You shouldn't see this..."

        Loading ->
            text "Loading..."

        Failure err ->
            text ("Error: " ++ toString err)

        Success projects ->
            listProjects projects


listProjects : Projects -> Html Msg
listProjects projects =
    div []
        [ text <| toString projects
        , button [ onClick OnLogout ] [ text "Logout" ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getProjects : Model -> Cmd Msg
getProjects =
    loadAuthenticated OnGetProjectsResult Decoders.decodeResponse "/projects"


loadAuthenticated : (WebData success -> Msg) -> Decode.Decoder success -> String -> Model -> Cmd Msg
loadAuthenticated toMsg decoder path model =
    let
        config =
            { headers = [ BasicAuth.buildAuthorizationHeader model.username model.password ]
            , withCredentials = False
            , timeout = Nothing
            }
    in
    RHttp.getWithConfig config (model.baseUrl ++ path) toMsg decoder
