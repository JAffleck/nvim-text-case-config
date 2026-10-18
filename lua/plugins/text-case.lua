  { -- untested AI Slop to use menus to select coercion scope/target
    "johmsalas/text-case.nvim",
    cmd = { "Subs", "S" },
    keys = {
      {
        "<Bslash><Bslash>c",
        function()
          require("textcase").show_menu()
        end,
        mode = { "n", "v" },
        desc = "Text Case Menu",
      },
    },
    config = function()
      local textcase = require("textcase")

      textcase.setup({
        default_keymappings_enabled = false,
        substitude_command_name = "S",
      })

      -- Custom menu using Neovim's native vim.ui.select
      function textcase.show_menu()
        local mode = vim.api.nvim_get_mode().mode
        local is_visual = mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode == "\22"

        -- The "Coerce to" options
        local case_options = {
          { label = "snake_case", method      = "to_snake_case" },
          { label = "CamelCase", method       = "to_camel_case" },
          { label = "PascalCase", method      = "to_pascal_case" },
          { label = "CONSTANT_CASE", method   = "to_constant_case" },
          { label = "dash-case", method       = "to_dash_case" },
          { label = "dot.case", method        = "to_dot_case" },
          { label = "comma,case", method      = "to_comma_case" },
          { label = "filepath/case", method   = "to_path_case" },
          { label = "Title Case", method      = "to_title_case" },
          { label = "Title-Dash-Case", method = "to_title_dash_case" },
          { label = "UPPER CASE", method      = "to_upper_case" },
          { label = "lower case", method      = "to_lower_case" },
          { label = "Phrase case", method     = "to_phrase_case" },
        }

        -- If in visual mode, skip the scope question and go straight to coercion
        if is_visual then
          vim.ui.select(case_options, {
            prompt = "Coerce visual selection to:",
            format_item = function(item)
              return item.label
            end,
          }, function(choice)
            if not choice then
              return
            end
            textcase.visual(choice.method)
          end)
          return
        end

        -- The "Scope" options for Normal mode
        local scope_options = {
          { label = "Current Word", method = "current_word" },
          { label = "Operator (wait for motion)", method = "operator" },
          { label = "Line", method = "line" },
          { label = "LSP Rename", method = "lsp_rename" },
        }

        -- 1st Question: Select Scope
        vim.ui.select(scope_options, {
          prompt = "Select Scope:",
          format_item = function(item)
            return item.label
          end,
        }, function(scope_choice)
          if not scope_choice then
            return
          end

          -- 2nd Question: Select Coercion target
          vim.ui.select(case_options, {
            prompt = "Coerce " .. scope_choice.label .. " to:",
            format_item = function(item)
              return item.label
            end,
          }, function(case_choice)
            if not case_choice then
              return
            end

            -- Execute the correct API based on the selected scope
            if scope_choice.method == "current_word" then
              textcase.current_word(case_choice.method)
            elseif scope_choice.method == "operator" then
              textcase.operator(case_choice.method)
            elseif scope_choice.method == "line" then
              textcase.line(case_choice.method)
            elseif scope_choice.method == "lsp_rename" then
              textcase.lsp_rename(case_choice.method)
            end
          end)
        end)
      end
    end,
  },
