pageextension 50102 "Transfer Order Subform Ext" extends "Transfer Order Subform"
{
    layout
    {
        // Add Unit Price after Unit of Measure
        addafter("Unit of Measure Code")
        {
            field("Unit Price Excl./Incl. VAT"; Rec."Unit Price Excl./Incl. VAT")
            {
                ApplicationArea = Warehouse;
                Caption = 'Unit Price Excl./Incl. VAT';
                ToolTip = 'Price from Sales Price List (if valid) or Item Card';
                Editable = false;
                Width = 8;
            }
        }

        // Add Line Amount after Unit Price
        addafter("Unit Price Excl./Incl. VAT")
        {
            field("Line Amount Excl./Incl. VAT"; Rec."Line Amount Excl./Incl. VAT")
            {
                ApplicationArea = Warehouse;
                Caption = 'Line Amount Excl./Incl. VAT';
                ToolTip = 'Calculated as: Unit Price × Quantity';
                Editable = false;
                Width = 8;
            }
        }

        // Add Confirmed Amount after Qty. Received
        addafter("Quantity Received")
        {
            field("Confirmed Line Amount Excl./Incl. VAT"; Rec."Confirmed Line Amount Excl./Incl. VAT")
            {
                ApplicationArea = Warehouse;
                Caption = 'Confirmed Line Amount Excl./Incl. VAT';
                ToolTip = 'Calculated as: Unit Price × Quantity Received';
                Editable = false;
                Width = 8;
            }
        }

        // Add totals BELOW the lines table (footer area)
        addafter(Control1) // This adds after the main repeater
        {
            group(FooterTotals)
            {
                ShowCaption = false;
                field("Total Amount to Deliver"; GetTotalAmountToDeliver())
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Total Amount to Deliver';
                    ToolTip = 'Sum of all line amounts';
                    Editable = false;
                    Style = Strong;
                }
                field("Total Amount Confirmed"; GetTotalConfirmedAmount())
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Total Amount Confirmed';
                    ToolTip = 'Sum of all confirmed amounts';
                    Editable = false;
                    Style = Strong;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalculatePrices();
        CalculateConfirmedAmount();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CalculatePrices();
        CalculateConfirmedAmount();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CalculatePrices();
        CalculateConfirmedAmount();
        UpdateHeaderTotals();
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        // Store document no before deletion
        DocNoToUpdate := Rec."Document No.";
        exit(true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // Final update when closing the page
        if DocNoToUpdate <> '' then
            UpdateSpecificHeaderTotals(DocNoToUpdate);
    end;

    var
        DocNoToUpdate: Code[20];

    // Unit Price and Line Amount Calculation 
    local procedure CalculatePrices()
    var
        TransferLinePriceCalculation: Codeunit "TransferLinePriceCalcu";
    begin
        if Rec."Item No." <> '' then begin
            Rec."Unit Price Excl./Incl. VAT" := TransferLinePriceCalculation.GetTransferLineUnitPrice(Rec);
            Rec."Line Amount Excl./Incl. VAT" := Rec."Unit Price Excl./Incl. VAT" * Rec.Quantity;
        end else begin
            Rec."Unit Price Excl./Incl. VAT" := 0;
            Rec."Line Amount Excl./Incl. VAT" := 0;
        end;
    end;

    local procedure CalculateConfirmedAmount()
    var
        TransferLinePriceCalculation: Codeunit "TransferLinePriceCalcu";
    begin
        if Rec."Item No." <> '' then
            Rec."Confirmed Line Amount Excl./Incl. VAT" := TransferLinePriceCalculation.CalculateConfirmedAmount(Rec)
        else
            Rec."Confirmed Line Amount Excl./Incl. VAT" := 0;
    end;

    //Transfer Order Subform Totals
    local procedure GetTotalAmountToDeliver(): Decimal
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", Rec."Document No.");
        TransferLine.SetRange("Quantity Shipped", 0); // Only non-posted lines
        TransferLine.CalcSums("Line Amount Excl./Incl. VAT");
        exit(TransferLine."Line Amount Excl./Incl. VAT");
    end;

    local procedure GetTotalConfirmedAmount(): Decimal
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", Rec."Document No.");
        TransferLine.CalcSums("Confirmed Line Amount Excl./Incl. VAT");
        exit(TransferLine."Confirmed Line Amount Excl./Incl. VAT");
    end;

    //Transfer Header Updating Total
    local procedure UpdateSpecificHeaderTotals(DocumentNo: Code[20])
    var
        TransferHeader: Record "Transfer Header";
        TransferLinePriceCalculation: Codeunit "TransferLinePriceCalcu";
    begin
        if TransferHeader.Get(DocumentNo) then begin
            TransferLinePriceCalculation.CalculateHeaderTotals(TransferHeader, true);
            TransferHeader.Modify();
        end;
    end;

    local procedure UpdateHeaderTotals()
    var
        TransferLinePriceCalculation: Codeunit "TransferLinePriceCalcu";
    begin
        TransferLinePriceCalculation.UpdateHeaderTotals(Rec);
    end;
}

