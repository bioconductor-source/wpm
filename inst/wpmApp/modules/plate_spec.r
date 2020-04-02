# This R script contains the UI and Server side of the app to manage the plates
# specifications.

# Module UI function
plateSpecUI <- function(id, label = "Plate specifications") {
  # Create a namespace function using the provided id
  ns <- NS(id)


  fluidRow(
    column(width=6,

      #-------------------------------------------------------------------------
      box(status="warning",
          width = 12,
          solidHeader = TRUE,
          title=h3("2 - Plate dimensions"),

          selectInput(ns("plate_size"),
                      label = NULL,
                      choices = c("6" = "s6",
                        "24" = "s24",
                        "48" = "s48",
                        "96" = "s96",
                        "384" = "s384",
                        "1536" = "s1536",
                        "custom" = "custom"
                      ),
                      selected = NULL),

          conditionalPanel(
            condition = "input.plate_size == 'custom'",
            h4("How many lines on your plate?"),
            numericInput(ns("plate_lines"), label = NULL,
                         value=0, min=0,
                         width = "80px"),
            h4("how many columns on your plate?"),
            numericInput(ns("plate_cols"), label = NULL,
                         value=0, min=0,
                         width = "80px"),
            ns = ns
          ),
          h4("How many plates?"),
          numericInput(ns("no_plates"), label = NULL,
                       value=1, min=1,
                       width = "80px")
      ),
      #-------------------------------------------------------------------------

      #-------------------------------------------------------------------------
      box(status="warning",
          width = 12,
          solidHeader = TRUE,
          title = h3("3 - Forbidden Wells"),
          fluidRow(
            column(width = 10,
                   p("Sometimes we do not want fill some wells because: We do
                     not want to fill the corners, there are broken pipettes,
                     there are dirty wells, ...")
            ),
            column(width = 2,
                   align = "right",
                   dropdownButton(
                     tags$h4("What does \"forbidden\" mean?"),
                     div("Forbidden means that the wells in question will not be
                         filled at all in the final plate plan.",br(),
                         "Consequently, during the experiment, these will be
                         completely empty wells"),
                     icon = icon("info-circle"),
                     tooltip = tooltipOptions(title = "Help"),
                     status = "warning",
                     size = "sm",
                     width = "350px"
                     ))
          ),


          textInput(ns("forbid_select"), h4("Enter Line Letter & Column number,
                                            each box separated by commas without spaces."),
                    value = NULL,
                    placeholder = "Ex: A1,B2,C3")
          ),
      #-------------------------------------------------------------------------

      #-------------------------------------------------------------------------
      box(status="warning",
          width = 12,
          solidHeader = TRUE,
          title=h3("4 - Blanks"),
          fluidRow(
            column(width = 10,
                   h4("How to place Blanks on the plate")
            ),
            column(width = 2,
                   align = "right",
                   dropdownButton(
                     tags$h4("What are blanks?"),
                     div("By blanks we mean a preparation without a biological sample in it.",
                         br(),
                         "You can place them in line or column. In these two cases
                         there will be blanks every other line/column."),
                     icon = icon("info-circle"),
                     tooltip = tooltipOptions(title = "Help"),
                     status = "warning",
                     size = "sm",
                     width = "350px"
                   ))
          ),

          fluidRow(
            column(width = 5,
                   awesomeRadio(inputId = ns("blank_mode"),
                                label = NULL,
                                choices = c("No blanks" = "none",
                                            "Per line" = "by_row",
                                            "Per column" = "by_column",
                                            "Checkerboard" = "checkerboard",
                                            "Choose by hand" = "by_hand"
                                ),
                                selected = NULL,
                                status = "warning"

                   )
                   ),
            column(width = 7,
                   conditionalPanel(condition = "input.blank_mode == 'by_row' | input.blank_mode == 'by_column'",
                                    awesomeRadio(inputId = ns("start_blank"),
                                                 label = h4("starting placing in:"),
                                                 choices = c("even" = "even",
                                                             "odd" = "odd"),
                                                 selected = NULL,
                                                 status = "warning"),
                                    ns = ns),
                   conditionalPanel(condition = "input.blank_mode == 'by_hand'",
                                    textInput(ns("hand_select"),
                                              h4("Enter Line Letter & Column number, each
                              box separated by commas without spaces.
                              \n The wells already filled as forbidden
                              will not be drawn as 'Blank'."),
                                              value = NULL,
                                              placeholder = "Ex: A1,B2,C3"),
                                    ns = ns)
                   )
          ),



          hr(),
          fluidRow(
            column(width = 10,
                   h4("Neighborhood contraints")
            ),
            column(width = 2,
                   align = "right",
                   dropdownButton(
                     tags$h4("What are neighborhood constraints?"),
                     div(""),
                     icon = icon("info-circle"),
                     tooltip = tooltipOptions(title = "Help"),
                     status = "warning",
                     size = "sm",
                     width = "350px"
                   ))
          ),



          conditionalPanel(condition = "input.blank_mode == 'by_row'",
                           awesomeRadio(inputId = ns("constraint_row"),
                                        label = NULL,
                                        choices = c(
                                                    "West-East" = "WE",
                                                    "None" = "none"),
                                        selected = NULL,
                                        status = "warning"

                           ),
                           ns = ns),
          conditionalPanel(condition = "input.blank_mode == 'by_column'",
                           awesomeRadio(inputId = ns("constraint_column"),
                                        label = NULL,
                                        choices = c("North-South" = "NS",
                                                    "None" = "none"),
                                        selected = NULL,
                                        status = "warning"

                           ),
                           ns = ns),



          conditionalPanel(condition = "input.blank_mode == 'none' & output.nb_gps > 3",
                           awesomeRadio(inputId = ns("constraint_none_sup3"),
                                        label = NULL,
                                        choices = c("North-South" = "NS",
                                                   "West-East" = "WE",
                                                   "North-South-West-East" = "NEWS",
                                                   "None" = "none"),
                                        selected = NULL,
                                        status = "warning"

                           ),
                           ns = ns),

          conditionalPanel(condition = "input.blank_mode == 'none' & output.nb_gps <= 3",
                           awesomeRadio(inputId = ns("constraint_none_inf3"),
                                        label = NULL,
                                        choices = c("North-South" = "NS",
                                                    "West-East" = "WE",
                                                    "None" = "none"),
                                        selected = NULL,
                                        status = "warning"

                           ),
                           ns = ns),



          conditionalPanel(condition = "input.blank_mode == 'by_hand' & output.nb_gps > 3",
                           awesomeRadio(inputId = ns("constraint_by_hand_sup3"),
                                        label = NULL,
                                        choices = c("North-South" = "NS",
                                                    "West-East" = "WE",
                                                    "North-South-West-East" = "NEWS",
                                                    "None" = "none"),
                                        selected = NULL,
                                        status = "warning"

                           ),
                           ns = ns),


          conditionalPanel(condition = "input.blank_mode == 'by_hand' & output.nb_gps <= 3",
                           awesomeRadio(inputId = ns("constraint_by_hand_inf3"),
                                        label = NULL,
                                        choices = c("North-South" = "NS",
                                                    "West-East" = "WE",
                                                    "None" = "none"),
                                        selected = NULL,
                                        status = "warning"

                           ),
                           ns = ns),

          conditionalPanel(condition = "input.blank_mode == 'checkerboard'",
                           div(
                             HTML(paste("You have selected the ",
                                        tags$span(style="color:red", "Checkerboard"),
                                        "mode, therefore there are no available neighborhood constraints.",
                                        sep = " ")
                             )
                           ),
                           ns = ns)
      ),
      #-------------------------------------------------------------------------

      #-------------------------------------------------------------------------
      box(status="warning",
          width = 12,
          solidHeader = TRUE,
          title = h3("5 - Not randomized Wells"),
          p("These samples will not be used for the backtracking algorithm.
              They correspond to Quality controls or Standards.")
          ,
          textInput(ns("notRandom_select"), h4("Enter Line Letter & Column number,
                                            each box separated by commas without spaces.\n
                                            The wells already filled as forbidden
                                            will not be drawn as 'Not Random'."),
                    value = NULL,
                    placeholder = "Ex: A1,B2,C3")
      )
      #-------------------------------------------------------------------------
    ),

    #-------------------------------------------------------------------------
    # Plate specification outputs
    column(width = 6,
           fluidRow(infoBoxOutput(ns("warning_plate"), width = 12)),
           fluidRow(valueBoxOutput(ns("total_nb_wells"), width = 6),
                    valueBoxOutput(ns("nb_plates_to_fill"), width = 6)
                    ),
           withLoader(
             plotOutput(ns("plotOut"), height = 500),
             type = "html",
             loader = "loader7"
           )

    )
    #-------------------------------------------------------------------------
  )
}

# Module server function
plateSpec <- function(input, output, session, nb_samp_gps, gp_levels, project_name, nb_samples) {

  toReturn <- reactiveValues(
    nb_lines = NULL,
    nb_cols = NULL,
    nb_plates = NULL,
    forbidden_wells = NULL,
    neighborhood_mod = NULL
  )


  p_lines <- reactive({
    switch (input$plate_size,
            NULL = {nb <- 0},
            "s6" = {nb <- 2},
            "s24" = {nb <-4},
            "s48" = {nb <-6},
            "s96" = {nb <-8},
            "s384" = {nb <-16},
            "s1536" = {nb <- 32},
            "custom" = {nb <- input$plate_lines}
    )
    return(nb)
  })

  p_cols <- reactive({
    switch (input$plate_size,
            NULL = {nb <- 0},
            "s6" = {nb <- 3},
            "s24" = {nb <-6},
            "s48" = {nb <-8},
            "s96" = {nb <-12},
            "s384" = {nb <-24},
            "s1536" = {nb <- 48},
            "custom" = {nb <- input$plate_cols}
    )
    return(nb)
  })

  nb_p <- reactive({
    if(is.na(input$no_plates)){
      return(0)
    }else{
      return(input$no_plates)
    }
  })

  totalNbWells <- reactive({
    tNbW <- p_lines()*p_cols()*nb_p()
    loginfo("totalNbWells = %d", tNbW, logger = "plate_spec")
    return(tNbW)
    })

  output$total_nb_wells <- renderValueBox({
    valueBox(value=totalNbWells(),
             subtitle = "Number of fillable wells",
             icon = icon("vials"),
             color="teal")
  })

  output$nb_plates_to_fill <- renderValueBox({
    valueBox(value=as.numeric(nb_p()),
             subtitle = "Number of plates to fill",
             icon = icon("dice-four"),
             color="teal")
  })

  output$warning_plate <- renderInfoBox({
    infoBox(title=HTML(paste("We assume that all the plates to be filled have the same dimensions.",
                       br(),
                       "Also, when you want to generate more than 1 plate,",
                       br(),
                       "WPM uses balanced group workforces to distribute the samples within the plates."
                         )),
            icon = icon("exclamation-triangle"),
            color = "red",
            fill=TRUE)
  })


  output$nb_gps <- reactive({
    return(nb_samp_gps())
  })

  outputOptions(output, "nb_gps", suspendWhenHidden = FALSE)



  forbid_wells <- reactive({
    # si des cases interdites on été saisies, alors on transforme en un df compatible
    # avec la suite du code
    if(input$forbid_select != ""){
      fw <- as.vector(unlist(base::strsplit(as.character(input$forbid_select),
                                      split=",")))
      return(convertVector2Df(fw, p_lines(), p_cols(), status = "forbidden"))
    }else{
      return(NULL)
    }
  })


  blank_wells <- reactive({

    validate(
      need((p_lines() > 0 & p_cols() > 0), "requires a plate with positive dimensions.")
    )
    if(input$blank_mode != "by_hand"){
      defineBlankCoords(p_lines(),
                         p_cols(),
                         as.character(input$blank_mode),
                         input$start_blank)
    }else{
      bw <- as.vector(unlist(base::strsplit(as.character(input$hand_select),
                                      split=",")))
      return(convertVector2Df(bw, p_lines(), p_cols(), status = "blank"))
    }

  })


  notRandom_wells <- reactive({
    validate(
      need((p_lines() > 0 & p_cols() > 0), "requires a plate with positive dimensions.")
    )
    if(input$notRandom_select != ""){
      fw <- as.vector(unlist(base::strsplit(as.character(input$notRandom_select),
                                      split=",")))
      return(convertVector2Df(fw, p_lines(), p_cols(), status = "notRandom"))
    }else{
      return(NULL)
    }

  })



  wells_to_plot <- reactive({
    ret <- NULL

    if(is.null(forbid_wells())){
      nb_f <- 0

    }else{
      nb_f <- nrow(forbid_wells())

    }

    if(is.null(blank_wells())){
      nb_b <- 0

    }else{
      nb_b <- nrow(blank_wells())

    }

    if(is.null(notRandom_wells())){
      nb_nR <- 0
    }else{
      nb_nR <- nrow(notRandom_wells())
    }

    validate(
      need(nb_samples() <= (totalNbWells()),
           "The dimensions of the plate are not compatible with the number of samples to be placed.
           Please increase the number of plates to fill or provide a dataset with fewer samples.")
    )


    # si forbidden
    if(!is.null(forbid_wells())){
      # si blanks
      if(!is.null(blank_wells())){
        # si NotRandom
        if(!is.null(notRandom_wells())){
          validate(
            need(nb_samples() <= (totalNbWells() - (nb_b*nb_p()) - (nb_f*nb_p()) - (nb_nR*nb_p())),
                 "The dimensions of the plate are not compatible with the number of samples to be placed.
                 Maybe are you specifying to many forbidden/blanks/notRandom wells.")
          )
          # We put the forbidden wells first because they have priority over the blanks ones.
          result <- base::rbind(forbid_wells(), blank_wells(), notRandom_wells())
          result <- dplyr::distinct(result, Row, Column, .keep_all = TRUE)
          ret <- result
        # si pas de NotRandom
        }else{
          validate(
            need(nb_samples() <= (totalNbWells() - (nb_b*nb_p()) - (nb_f*nb_p())),
                 "The blank mode and/or forbidden wells selected are not compatible with the plate's dimensions and the number of samples to be placed.
                 If you want to keep this blank mode, please increase the number of plates to fill or provide a dataset with fewer samples.
                 Otherwise, please change the blank mode.")
            )
          # We put the forbidden wells first because they have priority over the blanks ones.
          result <- base::rbind(forbid_wells(), blank_wells())
          result <- dplyr::distinct(result, Row, Column, .keep_all = TRUE)
          ret <- result
        }
      # si pas de blanks
      }else{
        # si NotRandom
        if(!is.null(notRandom_wells())){
          validate(
            need(nb_samples() <= (totalNbWells() - (nb_f*nb_p()) - (nb_nR*nb_p()) ),
                 "The dimensions of the plate are not compatible with the number of samples to be placed.
                 Maybe are you specifying to many forbidden/notRandom wells."
            )
          )
          result <- base::rbind(forbid_wells(), notRandom_wells())
          result <- dplyr::distinct(result, Row, Column, .keep_all = TRUE)
          ret <- result
        # si pas de NotRandom
        }else{
          validate(
            need(nb_samples() <= (totalNbWells() - (nb_f*nb_p())),
                 "The forbidden wells selected are not compatible with the plate's dimensions and the number of samples to be placed.
                 To solve this issue, please:
                 - decrease the number of forbidden wells
                 - or increase the number of plates to fill
                 - or provide a dataset with fewer samples.")
            )
          ret <- forbid_wells()
        }
      }

    # sinon
    }else{
      # si blanks
      if(!is.null(blank_wells())){
        # si NotRandom
        if(!is.null(notRandom_wells())){
          validate(
            need(nb_samples() <= ( totalNbWells() - (nb_b*nb_p()) - (nb_nR*nb_p()) ),
                   "The dimensions of the plate are not compatible with the number of samples to be placed.
                 Maybe are you specifying to many blanks/notRandom wells."
                   )
            )
          result <- base::rbind(blank_wells(), notRandom_wells())
          result <- distinct(result, Row, Column, .keep_all = TRUE)
          ret <- result
          # si pas de NotRandom
        }else{
          validate(
            need(nb_samples() <= (totalNbWells() - (nb_b*nb_p())),
                 "The blank mode selected is not compatible with the plate's dimensions and the number of samples to be placed.
                 If you want to keep this blank mode, please increase the number of plates to fill or provide a dataset with fewer samples.
                 Otherwise, please change the blank mode.")
            )
          ret <- blank_wells()
        }
        # si pas de blanks
      }else{
        # si NotRandom
        if(!is.null(notRandom_wells())){
          validate(
            need(nb_samples() <= totalNbWells() - (nb_nR*nb_p()),
              "The dimensions of the plate are not compatible with the number of samples to be placed.
                 Maybe are you specifying to many notRandom wells."
            )
          )
          ret <- notRandom_wells()
          # si pas de NotRandom
        }else{
          ret <- NULL
        }
      }
    }

    return(ret)
  })


  output$plotOut <- renderPlot({
    # pour que la fonction drawMap fonctionne, il faut donner un nombre de
    # lignes et de colonnes > 0 et au minimum un dataframe vide avec les bons
    # noms de colonne

    if(p_lines() != 0 & p_cols() != 0){
      # loginfo("wells_to_plots: %s", is.null(wells_to_plot()))
      if(is.null(wells_to_plot())){

        df <- setnames(data.table::setDF(lapply(c(NA, NA, NA, NA, NA, NA), function(...) character(0))),
                       c("Sample.name", "Group", "Well", "Status", "Row", "Column"))
        drawMap(df = df,
                     sample_gps = nb_samp_gps(),
                     gp_levels = gp_levels(),
                     plate_lines = p_lines(),
                     plate_cols = p_cols(),
                     project_title = project_name())
      }else{

        drawMap(df = wells_to_plot(),
                     sample_gps = nb_samp_gps(),
                     gp_levels = gp_levels(),
                     plate_lines = p_lines(),
                     plate_cols = p_cols(),
                     project_title = project_name())
      }
    }
  })

  nbh_mod <- reactive({
    nbh_mod <- NULL
    if(input$blank_mode == "by_row"){
      nbh_mod <- input$constraint_row

    }else if(input$blank_mode == "by_column"){
      nbh_mod <- input$constraint_column

    }else if(input$blank_mode == "by_hand"){
      if(nb_samp_gps() > 3){
        nbh_mod <- input$constraint_by_hand_sup3
      }else{
        nbh_mod <- input$constraint_by_hand_inf3
      }

    }else if(input$blank_mode == "none"){
      if(nb_samp_gps() > 3){
        nbh_mod <- input$constraint_none_sup3
      }else{
        nbh_mod <- input$constraint_none_inf3
      }

    }else if(input$blank_mode == "checkerboard"){
      nbh_mod <- "none"
    }

    return(nbh_mod)
  })

  observe({
    toReturn$nb_lines <- p_lines()
    toReturn$nb_cols <- p_cols()
    toReturn$nb_plates <- nb_p()
    # dataframe which contains the blanks and forbidden wells
    toReturn$forbidden_wells <- wells_to_plot()
    toReturn$neighborhood_mod <- nbh_mod()
  })

  return(toReturn)
}