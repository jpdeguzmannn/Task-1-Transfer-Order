pageextension 50102 "TransferOrderSubformExtension" extends "Transfer Order Subform"
{
    layout
    {
        // Add Unit Price Excl./Incl. VAT after Unit of Measure Code
        addafter("Unit of Measure Code")
        {
            field("Unit Price Excl./Incl. VAT"; Rec."Unit Price Excl./Incl. VAT")
            {
                ApplicationArea = All;
                Caption = 'Unit Price Excl./Incl. VAT';
                ToolTip = 'Shows the Unit Price from the Default Sales Price List or Item Card';
                Editable = false;
            }
        }

        // Add Line Amount Excl./Incl. VAT after Unit Price Excl./Incl. VAT
        addafter("Unit Price Excl./Incl. VAT")
        {
            field("Line Amount Excl./Incl. VAT"; Rec."Line Amount Excl./Incl. VAT")
            {
                ApplicationArea = All;
                Caption = 'Line Amount Excl./Incl. VAT';
                ToolTip = 'Unit Price Excl./Incl. VAT multiplied by Quantity';
                Editable = false;
            }
        }

        // Add Confirmed Line Amount Excl./Incl. VAT after Qty. Received
        addafter("Quantity Received")
        {
            field("Confirmed Line Amount Excl./Incl. VAT"; Rec."Confirmed Line Amount Excl./Incl. VAT")
            {
                ApplicationArea = All;
                Caption = 'Confirmed Line Amount Excl./Incl. VAT';
                ToolTip = 'Unit Price Excl./Incl. VAT multiplied by Quantity Received';
                Editable = false;
            }
        }

        // Add Total Amount to Deliver and Total Amount Confirmed at the end of the FastTab
        addlast(Control1)
        {
            field("Total Amount to Deliver"; Rec."Total Amount to Deliver")
            {
                ApplicationArea = All;
                Caption = 'Total Amount to Deliver';
                ToolTip = 'Sum of all Line Amount Excl./Incl. VAT in the Lines FastTab';
                Editable = false;
            }
            field("Total Amount Confirmed"; Rec."Total Amount Confirmed")
            {
                ApplicationArea = All;
                Caption = 'Total Amount Confirmed';
                ToolTip = 'Sum of all Confirmed Line Amount Excl./Incl. VAT in the Lines FastTab';
                Editable = false;
            }
        }
    }
}